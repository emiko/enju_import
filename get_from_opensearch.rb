require 'open-uri'

p "start #{Time.now}"
year = ARGV[0]
1.upto(12) do |month|
  50.times do |index|
    url = "http://iss.ndl.go.jp/api/opensearch?until=#{year}-#{month.to_s.rjust(2,'0')}-30&from=#{year}-#{month.to_s.rjust(2,'0')}-01&cnt=500&mediatype[]=1&idx=#{index+1}&op_id=1"
    os = open(url)
    datas = os.read
    dir = "import/#{year}/"
    FileUtils.mkdir_p(dir) unless FileTest.exist?(dir)
    File.open("#{dir}datas#{month}_#{index}.xml", "w") do |f|
      f.print datas
      p "created #{year}#{month}_#{index} #{Time.now}"
    end
  end
end
p "end #{Time.now}"

