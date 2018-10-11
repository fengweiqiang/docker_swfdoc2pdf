require 'socket'
server = TCPServer.new 4012

# 此服务提供http接口供容器外调用
# 使用/usr/bin/chrome-headless-render-pdf将html转为pdf，并存储中共享目录中
# 调用方法：curl http://127.0.0.1:4012/xxxx/output.html
# 最终生成output.pdf

WORK_DIR = '/var/tmp'

def call_html2pdf(task_id)
  url = "http://swfdoc-nginx/#{task_id}/output.html"
  pdf_path = WORK_DIR + "/#{task_id}/output.pdf"
  cmd = %{/usr/bin/chrome-headless-render-pdf --url #{url} --pdf #{pdf_path} --window-size 827,1169}

  %x{#{cmd}}

  return "/#{task_id}/output.pdf"
end

while session = server.accept
  request = session.gets
  puts request

  file_path = request.split(' ')[1]

  puts file_path

  result = call_html2pdf(file_path.split('/')[1])

  session.print "HTTP/1.1 200\r\n" # 1
  session.print "Content-Type: text/html\r\n" # 2
  session.print "\r\n" # 3
  session.print result

  session.close
end