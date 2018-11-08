require 'socket'
server = TCPServer.new 4012
require 'prawn'
require 'prawn/measurement_extensions'
require 'rest-client'

# 此服务提供http接口供容器外调用
# 使用prawn将jpg转为pdf，并存储中共享目录中
# 调用方法：curl http://127.0.0.1:4012/xxxx/output.html
# 最终生成output.pdf

WORK_DIR = '/var/tmp'

def call_prawn(task_id)
  url = "http://swfdoc-nginx/#{task_id}/output.html"
  pdf_path = WORK_DIR + "/#{task_id}/output.pdf"
  
  jpgs = IO.read(WORK_DIR + "/#{task_id}/jpgs.txt")
  ids = jpgs.gsub("\n","").split(',')
  Prawn::Document.generate(pdf_path, :margin=>0, :page_size=>'A4') do
    ids.each do |num|
      image  WORK_DIR + "/#{task_id}/#{num}", :width=>208.mm
      start_new_page(:size => 'A4', :layout => :portrait) if ids.last!=num
    end
  end
  return "/#{task_id}/output.pdf"
end

while session = server.accept
  request = session.gets
  puts request

  file_path = request.split(' ')[1]

  puts file_path

  result = call_prawn(file_path.split('/')[1])

  session.print "HTTP/1.1 200\r\n" # 1
  session.print "Content-Type: text/html\r\n" # 2
  session.print "\r\n" # 3
  session.print result

  session.close
end