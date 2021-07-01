module BurnsAeon
  class ContainerMapper < ItemMapper

    RequestList.register_item_mapper(self, :burns_aeon, Container)

    def request_permitted?(item)
      # only if only one resource
      item['json']['collection'].length < 2
    end


    def form_fields(mapped)
      [as_aeon_request(with_mapped_container(mapped, {
        'Site'           => mapped.ext(:site).name,
        'ReferenceNumber' => mapped.ext(:hollis).id,
        'ItemTitle'      => mapped.collection.name,
        'ItemAuthor'     => mapped.creator.name,
        'ItemDate'       => mapped.date.name,
        'Location'       => mapped.ext(:location).name,
        'SubLocation'    => mapped.ext(:physical_location).name,
        'CallNumber'     => mapped.collection.id,
        'ItemInfo2'      => mapped.collection.ext(:access_restrictions),
      }, mapped.container.multi.first))]
    end

  end
end
