p "start at #{Time.now}"
# set shelf name
shelves = ["honkan01", "honkan02", "honkan02_in_process", "bunkan01", "bunkan01_in_process", 
           "bunkan02", "bunka02_in_process", "bunkan03", "bunkan03_in_process"]
# set item_identifier prefix
pre = "L8"

# create data
require "rexml/document"
require "time"
require 'csv'

12.times do |month|
  month += 1
  datas = []
  arg = ARGV[0]
  Dir["./import/#{arg}/datas#{month}*.xml"].each do |file|
    begin
      doc = REXML::Document.new File.new(file)
      doc.elements.each("rss/channel/item") do |item|
        data = Hash.new
        data[:isbn] = item.elements["dcndl:ISBN"].text rescue nil
        data[:original_title] = item.elements["title"].text rescue nil
        data[:title_transcription] = item.elements["dcndl:titleTranscription"].text rescue nil
        data[:volume_number_string] = item.elements["dcndl:volume"].text rescue nil
        data[:issue_number_string] = item.elements["dcterms:issued xsi:type=\"dcterms:W3CDTF\""].text rescue nil
        data[:ndl_bib_id] = item.elements["dc:identifier xsi:type=\"dcndl:JPNO\""].text rescue nil
        authors = item.elements["author"].text rescue nil
        data[:creator] = authors.gsub(",",";") if authors
if false
      authors.split(",").each_with_index do |a, index|
        break if index > 2
        data[:"author#{index+1}"] = a
      end
end
        data[:pub_date] = Time.rfc822(item.elements["pubDate"].text).strftime("%Y/%m/%d") rescue nil
        datas << data
      end
    rescue => e
      p e
    end
  end
  p datas.size
  next if datas.size == 0
# export TSV
  CSV.open("import_#{arg}#{month}.txt", 'w', {:col_sep => "\t"}) do |row|
    columns = ["", :kbn, :item_identifier, :isbn, :original_title, :title_transcription,
             :pub_date, :volume_number_string, :issue_number_string, :creator, :shelf, :item_price, :call_number, "\n"]
    # header
    row << columns
    # manifestation datas
    i = 1
    datas.each do |data|
      csv_data = []

      columns.each do |column|
        case column
        when "" || "\n"
          csv_data << column
        when :kbn
          csv_data << "1"
        when :item_identifier
          csv_data << "#{pre}#{month}#{sprintf('%05d', i+=1)}"
        when :shelf
          csv_data << shelves[rand(shelves.length)] 
        else
          csv_data << data[column] rescue ""
        end
      end   
      row << csv_data
    end
  end
end
p "end at #{Time.now}"
