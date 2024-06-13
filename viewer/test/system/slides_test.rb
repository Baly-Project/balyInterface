require "application_system_test_case"

class SlidesTest < ApplicationSystemTestCase
  setup do
    @slide = slides(:one)
  end

  test "visiting the index" do
    visit slides_url
    assert_selector "h1", text: "Slides"
  end

  test "should create slide" do
    visit slides_url
    click_on "New slide"

    fill_in "Abstract", with: @slide.abstract
    fill_in "Author1 fname", with: @slide.author1_fname
    fill_in "Author1 lname", with: @slide.author1_lname
    fill_in "Calc url", with: @slide.calc_url
    fill_in "Context key", with: @slide.context_key
    fill_in "Coverage spatial", with: @slide.coverage_spatial
    fill_in "Document type", with: @slide.document_type
    fill_in "Identifier", with: @slide.identifier
    fill_in "Image notes", with: @slide.image_notes
    fill_in "Keywords", with: @slide.keywords
    fill_in "Publication date", with: @slide.publication_date
    fill_in "Subcollection", with: @slide.subcollection
    fill_in "Title", with: @slide.title
    click_on "Create Slide"

    assert_text "Slide was successfully created"
    click_on "Back"
  end

  test "should update Slide" do
    visit slide_url(@slide)
    click_on "Edit this slide", match: :first

    fill_in "Abstract", with: @slide.abstract
    fill_in "Author1 fname", with: @slide.author1_fname
    fill_in "Author1 lname", with: @slide.author1_lname
    fill_in "Calc url", with: @slide.calc_url
    fill_in "Context key", with: @slide.context_key
    fill_in "Coverage spatial", with: @slide.coverage_spatial
    fill_in "Document type", with: @slide.document_type
    fill_in "Identifier", with: @slide.identifier
    fill_in "Image notes", with: @slide.image_notes
    fill_in "Keywords", with: @slide.keywords
    fill_in "Publication date", with: @slide.publication_date
    fill_in "Subcollection", with: @slide.subcollection
    fill_in "Title", with: @slide.title
    click_on "Update Slide"

    assert_text "Slide was successfully updated"
    click_on "Back"
  end

  test "should destroy Slide" do
    visit slide_url(@slide)
    click_on "Destroy this slide", match: :first

    assert_text "Slide was successfully destroyed"
  end
end
