require 'socket'
server = TCPServer.new 4010

# 此服务提供http接口供容器外调用
# 使用swftools中的swfextract提取jpg文件，并存储中共享目录中
# 调用方法：curl http://127.0.0.1:4010/xxx.swf
# 会随机生成一个任务ID（例如ande3dake）
# 最终生成ande3dake/output.html供调用

WORK_DIR = '/var/tmp'

@html_template = %{
<!Doctype html><html xmlns=http://www.w3.org/1999/xhtml>
<head>
<meta http-equiv=Content-Type content="text/html;charset=utf-8" />
<style type="text/css">
body, img, div, p{
margin:0; padding: 0;
}
.pageBreak{
  width: 100%;
}
img{
  width: 800px;
  height: 1050px;
}
</style>
</head>
<body>
$img$
</body>
</html>
}

def gen_random_task_id
  chars = ('a'..'z').to_a + (0..9).to_a
  (1..8).map{|i| chars[rand(chars.size)]}.join
end

def call_swfextract(swf_file, task_id)
  _file = WORK_DIR + '/' + swf_file
  return '404' if !File.exist?(_file)

  _task_dir = WORK_DIR + '/' + task_id
  Dir.mkdir(_task_dir) unless File.exist?(_task_dir)

  result = %x{swfextract #{_file}}

  if result.include?('JPEGs:') || result.include?('PNGs:')
    line = result.split("\n")
    ids = line[2].split('ID(s)').last.strip.split(", ")

    img_type_params = result.include?('JPEGs:') ? '-j' : '-p'

    html = ids.map{|id| %{<div class="pageBreak"><img src="#{id}.jpg"/></div>}}.join
    jpgs = ids.map{|id| "#{id}.jpg"}.join(',')
    File.open(_task_dir + "/output.html", "a+") do |f|
      f.puts @html_template.gsub('$img$', html)
    end

    File.open(_task_dir + "/jpgs.txt", "a+") do |f|
      f.puts jpgs
    end

    ids.each do |id|
      cmd = "swfextract #{img_type_params} #{id} -o #{_task_dir + "/#{id}"}.jpg #{_file}"
      %x{#{cmd}}
    end
    return "/#{task_id}/output.html"
  else
    return 'ERROR'
  end
end

while session = server.accept
  request = session.gets
  puts request

  url = request.split(' ')[1]

  if url.start_with?('/down?url=')
    file_url = url.split('/down?url=').last
    swf_file = [gen_random_task_id, '.swf'].join
    %x{curl #{file_url} > /var/tmp/#{swf_file}}
    result = swf_file
  else
    swf_file = url
    puts swf_file
    task_id = gen_random_task_id
    result = call_swfextract(swf_file, task_id)
  end

  session.print "HTTP/1.1 200\r\n" # 1
  session.print "Content-Type: text/html\r\n" # 2
  session.print "\r\n" # 3
  session.print result

  session.close
end