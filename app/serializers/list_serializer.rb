class ListSerializer
  include JSONAPI::Serializer
  attributes :title
  attributes :items do |lista|
    ItemSerializer.new(lista.items.order(position: :asc)).serializable_hash
  end
end
