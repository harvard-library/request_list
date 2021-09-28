module BurnsAeon
  class ListMapper < RequestListMapper

    RequestList.register_list_mapper(self, :burns_aeon)

    def form_fields
      {
        'SystemId'              => 'ArchivesSpace',
        'ReturnLinkURL'         => AppConfig[:public_proxy_url] + '/plugin/request_list/list',
        'ReturnLinkSystemName'  => @opts[:return_link_label],
        'AeonForm'              => 'ExternalRequest',
        'WebRequestForm'        => 'GenericRequestManuscript',
        'DocumentType'          => 'Default',
        'RequestType'           => 'Loan',
        'UserReview'            => 'No',
        'SkipOrderEstimate'     => '',
        'SubmitButton'          => 'Submit Request',

        'GroupRequestsByLocation'        => 'Yes',
        'GroupingIdentifier'             => 'gid',
        'GroupingOption_Site'            => 'FirstValue',
        'GroupingOption_ItemInfo2'       => 'FirstValue',
        'GroupingOption_ItemTitle'       => 'FirstValue',
        'GroupingOption_ItemSubTitle'    => 'Concatenate',
        'GroupingOption_ItemCitation'    => 'FirstValue',
        'GroupingOption_ItemAuthor'      => 'FirstValue',
        'GroupingOption_ItemDate'        => 'Concatenate',
        'GroupingOption_Location'        => 'FirstValue',
        'GroupingOption_SubLocation'     => 'FirstValue',
        'GroupingOption_ItemInfo3'       => 'Concatenate',
        'GroupingOption_CallNumber'      => 'FirstValue',
        'GroupingOption_ItemPlace'       => 'Concatenate',
        'GroupingOption_ItemIssue'       => 'Concatenate',
        'GroupingOption_ItemVolume'      => 'FirstValue',
        'GroupingOption_ItemNumber'      => 'FirstValue',
        'GroupingOption_ItemIssue'       => 'Concatenate',
        'GroupingOption_ItemInfo5'       => 'FirstValue',
        'GroupingOption_ReferenceNumber' => 'FirstValue',
      }
    end

  end
end
