class Product

  index_name BONSAI_INDEX_NAME

  tire do
    mapping do
      indexes :id,           index: :not_analyzed
      indexes :name,          analyzer: 'snowball', boost: 100
      indexes :primary_color, analyzer: 'snowball', boost: 50
      indexes :secondary_color, analyzer: 'snowball', boost: 25
      indexes :gender,       analyzer: 'snowball', boost: 25
      indexes :fabric,       analyzer: 'snowball', boost: 25
      indexes :pattern,      analyzer: 'snowball', boost: 25
      indexes :fit,          analyzer: 'snowball', boost: 25
      indexes :style,        analyzer: 'snowball', boost: 25
      indexes :category,     analyzer: 'snowball', boost: 50
      indexes :sub_category,   analyzer: 'snowball', boost: 100
      indexes :sub_sub_category,   analyzer: 'snowball', boost: 150
      indexes :tags,         analyzer: 'snowball'
      indexes :description,  analyzer: 'snowball'
      indexes :brand,        analyzer: 'snowball'
      indexes :visible,      analyzer: 'keyword'
      indexes :created_at,   type: 'date', include_in_all: false
      indexes :lat_lon,      type: 'geo_point'
    end
  end

  def to_indexed_json
    {
      _id: id,
      name: name,
      style: style,
      gender: gender,
      primary_color: primary_color,
      secondary_color: secondary_color,
      fabric: fabric,
      pattern: pattern,
      fit: fit,
      category: category,
      sub_category: sub_category,
      sub_sub_category: sub_sub_category,
      brand: brand.try(:name),
      description: description,
      tags: tags.pluck(:name),
      created_at: created_at,
      visible: visibility,
      lat_lon: stores.first.try(:lat_lon) || [0, 0],
    }.to_json
  end
  # end of search methods

end
