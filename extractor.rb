require 'csv'
require 'sqlite3'

class Extractor
  SUPPORTED_EXTENSIONS = ['csv','txt']
  def initialize
    # initializing instance variables
    @extension = nil
    @result = Array.new
  end

  # method for extracting extension of the file
  def get_extension(file_name)
    # check if file name contains '.' and it's not the last character
    if (file_name.include? '.') && (file_name[-1] != '.') 
      # get last element of splitted array which means extension of the file
      extension = file_name.split('.')[-1]
      # check support of extension
      if SUPPORTED_EXTENSIONS.include? extension
        @extension = extension
        return true
      else
        puts "Unsupported extension."
        return false
      end
    else
      puts "Filename doesn't contain extension."
    end
  end

  # method which performs printing results to console if output file is not specified
  def output_to_console
    @result.each do |row|
      puts row
    end
  end

  # method which performs output process to the file if output file name is specified
  def output_to_file(output_filename)
    case @extension
    when 'csv'
      CSV.open(output_filename, "w") do |csv|
        # get headers and put to the file
        csv << @result.shift
        # get every row and put to the file
        @result.each do |row|
          csv << row
        end
      end
    when 'txt'
      File.open(output_filename, 'w') do |file|
        file << @result.shift
        @result.each do |row|
          file << row
        end
      end
    end
  end

  # main method which performs all the logic of extracting
  def extract(input_filename, target_column, regex, output_filename=nil)
    if get_extension(input_filename)
      case @extension
      when 'csv'
        # get headers from the file
        headers = CSV.open(input_filename, &:readline)
        if headers.include? target_column
          # find index of target column
          column_index = headers.find_index(target_column)
          # put headers to instance variable result
          @result.push headers
          CSV.foreach(input_filename, headers: true) do |row| 
            if row[column_index] =~ regex
              @result.push row
            end
          end
          if output_filename.nil? || output_filename == ""
            output_to_console
          else
            output_to_file(output_filename)
          end
        else
          puts "There is no such column header."
        end
      when 'txt'
        headers = File.open(input_filename, &:readline)
        if headers.gsub(/\n/, "").split.include? target_column
          column_index = headers.gsub(/\n/, "").split.find_index(target_column)
          @result.push headers
          File.open('input.txt').drop(1).each do |line|  
            if line.gsub(/\n/, "").split[column_index] =~ regex
              @result.push line
            end
          end  
          if output_filename.nil? || output_filename == ""
            output_to_console
          else
            output_to_file(output_filename)
          end
        else
          puts "There is no such column header."
        end
      else 
        puts "Extension error."
      end
    else
      puts "Unrecognized extension."
    end
  end
end

puts "Enter input filename: "
input = gets.chomp
puts "Enter column to validate: "
column = gets.chomp
puts "Enter regex: "
regex = gets.chomp
puts "Enter output filename of leave empty to output to console: "
output = gets.chomp

extr = Extractor.new
extr.extract(input, column, Regexp.new(regex), output)

#\A\p{Alnum}+\z - only letters and numbers
