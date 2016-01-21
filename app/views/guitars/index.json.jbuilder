json.array!(@guitars) do |guitar|
  json.extract! guitar, :id, :name, :price
  json.url guitar_url(guitar, format: :json)
end
