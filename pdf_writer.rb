# https://www.loom.com/share/19e10fe977d44cd5a5100564688b88cf
# vanhackpdf
require 'csv'
require 'securerandom'

class PdfWriter

  PDF_TEMPLATE_FILENAME = 'template.pdf'
  attr_writer :fields

  def initialize(fields)
    @fields = fields
    @student_id = SecureRandom.hex(4)
    @fdf_file_name = "student-#{@student_id}.fdf"
    @pdf_file_name = "student-#{@student_id}.pdf"
  end

  def generate_fdf_file
    clear_fdf_files
    File.new(@fdf_file_name,"w").write( fdf_string )
  end

  def generate_pdf_file
    generate_fdf_file

    `#{pdftk_path} #{PDF_TEMPLATE_FILENAME} fill_form #{@fdf_file_name} output #{@pdf_file_name}`
    clear_fdf_files
  end

  def clear_fdf_files
    Dir.glob("*.fdf").each do |file|
      File.delete(file)
    end
  end

  private

  def pdftk_path
    path =  ENV['PDFTK_PATH'] || "/snap/bin/pdftk"
    if !File.exists?(path)
      puts "Could not locate Pdftk binary in your system. \n Please install and set PDFTK_PATH environment variable"
      exit()
    end
    path
  end

  def fdf_string
    header + @fields.map {|f| encode_field(f)}.join + footer
  end

  def header
    "%FDF-1.2\n\n1 0 obj\n<<\n/FDF << /Fields 2 0 R>>\n>>\nendobj\n2 0 obj\n["
  end
  
  def footer
    "]\nendobj\ntrailer\n<<\n/Root 1 0 R\n\n>>\n%%EOF\n"
  end

  def encode_field(field)
    results = "<< /T (#{field[0] }) /V "
    value = field[1]

    results <<
      if value.is_a?(Array)
        '[' + value.map {|v| "(#{quote(v)})"}.join + ']'
      else
        "(#{quote(value )})"
      end

    results << ">>\n"
    results
  end

  def quote (value)
    value.to_s.strip.
      gsub(/\\/, '\\').
      gsub(/\(/, '\(').
      gsub(/\)/, '\)').
      gsub(/\n/, '\r')
  end

end

student_data = CSV.parse(File.read("ruby_data.csv"), headers: :first_row).map(&:to_h)

student_data.each do |student|
  student = PdfWriter.new(student)
  student.generate_pdf_file
end
