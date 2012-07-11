p "start at #{Time.now}"
# set shelf name
shelves = ["hq1f001", "hq1f002", "hq1f003", "hq1f004", "hq1f005", "hq1f006", "hq1f007", "hq1f008",
           "hq2f001", "hq2f002", "hq2f003", "hq2f004", "hq2f005", "hq2f006", "hq2f007", "hq1b001",
           "anex1_1f001", "anex1_1f002", "anex1_1f003", "anex1_1f004", "anex1_1f005", "anex1_1f006",
           "anex1_1f900", "anex2_1f001", "anex2_1f002", "anex2_1f003", "anex2_1f004", "anex2_1f005", "anex2_1f006",
           "anex3_1f001", "anex3_1f002", "anex3_1f003", "anex3_1f004", "anex3_1f005", "anex3_1f006", "hq2f008"] 

# create data
require "rexml/document"
require "time"
datas = []
arg = ARGV[0]
Dir["./import/#{arg}/datas*.xml"].each do |file|
  begin
    doc = REXML::Document.new File.new(file)
    doc.elements.each("rss/channel/item") do |item|
      data = Hash.new
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
# export TSV
require 'csv'
CSV.open("import_#{arg}.txt", 'w', {:col_sep => "\t"}) do |row|
  columns = ["", :kbn, :item_identifier, :original_title, :title_transcription,
             :pub_date, :volume_number_string, :issue_number_string, :creator, :shelf, :item_price, :call_number, "\n"]
  # header
  row << columns
  # manifestation datas
  i = 2168594
  datas.each do |data|
    csv_data = []
#    p "printing record #{data[0]} : #{data[1]}"
    columns.each do |column|
      case column
      when "" || "\n"
        csv_data << column
      when :kbn
        csv_data << "1"
      when :item_identifier
        csv_data << "L#{sprintf('%07d', i+=1)}"
      when :shelf
        csv_data << shelves[rand(shelves.length)] 
      else
        csv_data << data[column] rescue ""
      end
    end   
    row << csv_data
  end
end
p "end at #{Time.now}"
