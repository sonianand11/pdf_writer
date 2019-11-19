require './pdf_writer.rb'
require "minitest/autorun"

class TestPdfWriter < Minitest::Test

  def setup
    @pdf_writer = PdfWriter.new([["EMP5624_E[0].Page1[0].Yes_business[0]", "anand"]])
  end
  
  def test_header
    assert_equal "%FDF-1.2\n\n1 0 obj\n<<\n/FDF << /Fields 2 0 R>>\n>>\nendobj\n2 0 obj\n[", @pdf_writer.send("header")
  end

  def test_footer
    assert_equal "]\nendobj\ntrailer\n<<\n/Root 1 0 R\n\n>>\n%%EOF\n", @pdf_writer.send("footer")
  end

  def test_quote
    result = @pdf_writer.send("quote", "anand")
    assert_equal "anand", result
  end

  def test_encode_field
    result = @pdf_writer.send("encode_field", ["EMP5624_E[0].Page1[0].Yes_business[0]", "anand"])
    assert_equal "<< /T (EMP5624_E[0].Page1[0].Yes_business[0]) /V (anand)>>\n", result
  end

  def test_fdf_string
    result = @pdf_writer.send("fdf_string")
    assert_equal true, result.is_a?(String)
    assert_equal true, result.include?("anand")
  end

  def test_pdftk_path
    result = @pdf_writer.send("pdftk_path")
    assert_equal true, result.is_a?(String)
  end

  def test_clear_fdf_files
    File.new("test1.fdf","w")
    assert_equal 1, Dir.glob("*.fdf").size
    Dir.glob("*.fdf").each do |file|
      File.delete(file)
    end
    assert_equal 0, Dir.glob("*.fdf").size
  end

  def test_generate_pdf_file
    student_data = CSV.parse(File.read("ruby_data.csv"), headers: :first_row).map(&:to_h)
    @pdf_writer.fields = student_data[0]
    @pdf_writer.generate_pdf_file
    assert_equal 2, Dir.glob("*.pdf").size
    assert_equal 0, Dir.glob("*.fdf").size
    Dir.glob("student-*.pdf").each do |file|
      File.delete(file)
    end
  end

  def test_generate_fdf_file
    @pdf_writer.generate_fdf_file
    assert_equal 1, Dir.glob("*.fdf").size
    @pdf_writer.clear_fdf_files
  end

end