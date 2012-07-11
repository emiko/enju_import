require 'open-uri'

p "start #{Time.now}"
i = 0
until i > 2
  num = 2007 - i
  1.upto(12) do |month|
    100.times do |index|
      url = "http://iss.ndl.go.jp/api/opensearch?until=#{num}-#{month.to_s.rjust(2,'0')}-30&from=#{num}-#{month.to_s.rjust(2,'0')}-01&cnt=500&mediatype=1&idx=#{index+1}"
      os = open(url)
      datas = os.read
      File.open("import/#{num}/datas#{month}_#{index}.xml", "w") do |f|
        f.print datas
        p "created #{num}#{month}_#{index} #{Time.now}"
      end
    end
  end
  i += 1
end
p "end #{Time.now}"

