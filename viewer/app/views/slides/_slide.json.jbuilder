json.extract! slide, :id, :title, :publication_date, :identifier, :subcollection, :image_notes, :document_type, :coverage_spatial, :keywords, :abstract, :author1_fname, :author1_lname, :calc_url, :context_key, :created_at, :updated_at
json.url slide_url(slide, format: :json)
