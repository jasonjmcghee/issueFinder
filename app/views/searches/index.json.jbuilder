json.array!(@searches) do |search|
  json.extract! search, 
  json.url search_url(search, format: :json)
end
