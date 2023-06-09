# frozen_string_literal: true

module Recipes
  class Entry
    def initialize(data)
      @data = data
    end

    def id
      @data['sys']['id']
    end

    def revision
      @data['sys']['revision']
    end

    def name
      @data['fields']['name']
    end

    def content_type
      @data['sys']['contentType']['sys']['id']
    end

    def title
      @data['fields']['title']
    end

    def description
      @data['fields']['description']
    end

    def photo_id
      @data['fields']['photo']['sys']['id']
    end

    def chef_id
      @data['fields']['chef']['sys']['id'] if @data['fields'].key?('chef')
    end

    def tag_ids
      return unless @data['fields'].key?('tags')

      @data['fields']['tags'].map { |tag| tag['sys']['id'] }
    end

    def calories
      @data['fields']['calories']
    end
  end
end
