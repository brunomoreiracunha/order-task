class ItemSerializer
    include JSONAPI::Serializer
    attributes :title, :list_id, :description

    attributes :members do |lista|
        UserSerializer.new(lista.members).serializable_hash
    end
end  