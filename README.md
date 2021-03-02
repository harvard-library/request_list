
# Request List

An ArchivesSpace Public User Interface plugin that allows sending lists of records to an external request system.

Developed against ArchivesSpace v2.3.2 by Hudson Molonglo for Harvard University.


## Summary

This plugin was designed to provide a generic means for selecting a list of items and then reviewing the list and performing an action on it.

It comes bundled with a profile for sending the list to Harvard's Aeon instance.

It is possible to develop a profile to send the list to some other external service. Instructions on doing this are in the Customization section.

The plugin is highly configurable and via configuration the behaviour can be customized for each repository in your ArchivesSpace instance. See the Configuration section.


## Installation

Follow standard ArchivesSpace plugin installation procedures.

This plugin is not dependent on any additional gems, does not require any database migrations, and does not override any existing templates.


## Configuration

The configuration for this plugin is fully contained within `AppConfig[:request_list]`. Below is a detailed description of the configuration options, followed by a complete example configuration.

If the plugin is being used to provide requesting (as it is with the bundled `:harvard_aeon` profile), you will probably want to turn off the standard ArchivesSpace request facility, like this:
```ruby
AppConfig[:pui_page_actions_request] = false
```

The `AppConfig[:request_list]` configuration contains a hash. The allowed key/value pair of this top level hash are:

```ruby
  :button_position => 0,
```
Optional. `:button_position` specifies the position of the `Add to My Request List` button among the other action buttons. By default it is added to the right of the other buttons. A value of `0` places it leftmost.

```ruby
  :record_types => ['archival_object', 'resource', 'top_container'],
```
Optional. `:record_types` specifies a list of ArchivesSpace JSONModel types that can be added to the list. The default is `['archival_object', 'accession']`.

```ruby
  :show_builtin_request_button_for_handled_repositories => true
```
Optional. If the builtin request button is enabled, then by default the builtin request button will only be shown for repositories that are not handled by request_list (see below). If this option is set to true, then the builtin request button will be shown for handled repositories. The default is `false`.

```ruby
  :request_handlers => { ... }
```

Required. Each key/value pair in `:request_handlers` defines a handler that is available for use by items from one or more repositories. Request handlers are discussed in detail below.

```ruby
  :repositories => {
    :default => {
      :handler => :harvard_test_aeon,
    },
    ...
  }
```

Required. The keys in `:repositories` are downcased `repo_code` or `:default`. Only the `:default` key is required. The values are hashes. The `:default` hash must contain a `:handler` key that points to a handler defined in the `:request_handlers` section. This says that, by default, items from all Repositories will use that handler. This can then be overridden in an entry for a particular Repository. The only other key supported is `:item_opts`. This is a hash of arguments passed to the item mapper.


### Request Handlers

Request Handlers are defined in the configuration under the `:request_handlers` key. The key of a handler is used in the `:repositories` section to specify which handler should be used for which Repositories. The value is a hash that has the following keys:

```ruby
  :name => 'Harvard Test Aeon',
```

Required. `:name` is a user-friendly label for the handler.

```ruby
  :profile => :harvard_aeon,
```

Required. `:profile` points to a defined profile that determines the mapping classes and form templates to use. See the Customization section below. The plugin currently ships with only the `:harvard_aeon` profile.

```ruby
  :url => 'https://somewhere.at.harvard.edu/logon',
```

Required. `:url` is the url that will be used for the form.

```ruby
  :list_opts => { ... }
```

Optional. `:list_opts` is a hash of arguments passed to the list mapper. It is used for list level customizations. The supported options are defined by the profile.


### Example:

```ruby
AppConfig[:pui_page_actions_request] = false

AppConfig[:request_list] = {
  :button_position => 0,
  :record_types => ['archival_object', 'resource', 'top_container'],

  :request_handlers => {
    :harvard_test_aeon => {
      :name => 'Harvard Test Aeon',
      :profile => :harvard_aeon,
      :url => 'https://somewhere.at.harvard.edu/logon',
      :list_opts => {
        :return_link_label => 'Return to HOLLIS',
        :form_target => 'harvard-library-requests',
        :aeon_link_url => 'https://somewhere.at.harvard.edu',
        :request_types => {
          'Reading room' => {
            'RequestType' => 'Loan',
            'UserReview' => 'No',
            'SkipOrderEstimate' => '',
          },
          'Saved' => {
            'RequestType' => 'Loan',
            'UserReview' => 'Yes',
            'SkipOrderEstimate' => '',
          },
          'Photoduplication' => {
            'RequestType' => 'Copy',
            'UserReview' => 'No',
            'SkipOrderEstimate' => 'Yes',
          }
        },
        :format_options => [
                            'Digital Prints',
                            'Existing Digital Images',
                            'Microfilm',
                            'Standard Digital Photography',
                            'Studio Digital Photography'
                           ],
        :delivery_options => [
                              'Campus Pickup',
                              'Mail',
                              'Online Delivery'
                             ]
      }
    }
  },

  :repositories => {
    :default => {
      :handler => :harvard_test_aeon,
    },
    'hua' => {
      :item_opts => {
        :excluded_request_types => ['Saved'],
      }
    },
    'arn' => {
      :item_opts => {
        :repo_fields => {
          'Site' => 'HUH'
        }
      }
    },
    'orc ' => {
      :item_opts => {
        :repo_fields => {
          'Site' => 'HUH'
        }
      }
    },
  }
}
```


## Customization

In the example config you will see the entry `:harvard_test_aeon` under `:request_handlers` has a `:profile` property with a value of `:harvard_aeon`.

The plugin ships with only this profile, but you can add new profiles from your own plugin - just be sure to list it after this one in your `AppConfig[:plugins]` list.

A handler's profile determines the mapping classes and form templates to use for that handler.


### Mapping Classes

A profile should provide one list mapping class and one or more item mapping classes.

A list mapping class is responsible for providing a hash of inputs that will apply to the whole list rather than for individual items.

See an example list mapper [here](https://github.com/hudmol/request_list/blob/master/public/models/harvard_aeon/list_mapper.rb).

The requirements for a list mapper class are:
  - It should subclass `RequestListMapper`
  - It should implement a `#form_fields` method that returns a hash of input names to values
  - It should register itself for one or more profiles
      eg. `RequestList.register_list_mapper(self, :harvard_aeon)` where `:harvard_aeon` is the profile name.

An item mapping class is responsible for taking an ArchivesSpace record, mapping it and providing a hash of inputs for an item in the list.

An item mapping class should subclass `RequestListItemMapper`

See an example item mapper [here](https://github.com/hudmol/request_list/blob/master/public/models/harvard_aeon/archival_object_mapper.rb).

The requirements for a item mapper class are:
  - It should subclass `RequestListItemMapper`
  - It should implement a `#form_fields(mapped)` method that returns a hash of input names to values for the `mapped` item
  - It should register itself for one or more profiles
      eg. `RequestList.register_item_mapper(self, :harvard_aeon, ArchivalObject)` where `:harvard_aeon` is the profile name, and `ArchivalObject` is the record type.

Item mapping classes can also define a `map_extensions(mapped, item, repository, resource, resource_json)` method to extend or modify the default item mapping. See the Mapped Item section.

### Mapped Items

The plugin maps incoming ArchivesSpace PUI objects to `RequestListMappedItem` objects. (See [here](https://github.com/hudmol/request_list/blob/master/public/models/request_list_mapped_item.rb)). A profile's item mapping classes can extend or modify the default mapping which is done [here](https://github.com/hudmol/request_list/blob/master/public/models/request_list_item_mapper.rb).

The mapped item is passed to the templates. It provides a simple and consistent interface for accesssing the properties of the item and its related records. The idea is to keep the complicated logic that is required to navigate PUI objects out of the templates. And since the default item mapper does most of the work, it is only necessary to define extensions in the profile's mapping classes. 


### Form Templates

Templates for rendering the form that will be sent when the submit button is clicked are organized by profile.

For example, the templates for the included profile `:harvard_aeon` are placed in their own directory, see [here](https://github.com/hudmol/request_list/tree/master/public/views/request_list/harvard_aeon).

### Note on Profiles

The plugin currently ships with only the `:harvard_aeon` profile. In the initial release of the plugin the separation of the `:harvard_aeon` profile from the core plugin is incomplete. For example in [request_list.js](https://github.com/hudmol/request_list/blob/master/public/assets/request_list.js) the `submitButtonClick` method contains a bunch of `:harvard_aeon` specific handling. So there is work to be done to complete the separation. In the meantime it is still feasible to develop new profiles, but just watch out for possible tangles. 
