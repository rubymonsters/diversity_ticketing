require 'test_helper'

class EventSearchServiceTest < ActiveSupport::TestCase

  describe 'filtering events by tags'  do
    describe 'with no events' do
      it 'returns no events' do
        tag = Tag.create!(id: 1, name: 'Ruby', category: Category.create!(name: 'Programming language'))
        assert_equal EventSearchService.new(query: '', filter: { tag_ids: ["1"] }).results, []
      end
    end

    describe 'with two events, one with matching tag' do
      before do
        @event = make_event
        other_event = make_event
        tag = Tag.create!(id: 1, name: 'Ruby', category: Category.create!(name: 'Programming language'))
        Tagging.create!(event: @event, tag: tag)
      end

      it 'returns only events that have a selected tag' do
        assert_equal EventSearchService.new(query: '', filter: { tag_ids: ["1"] }).results, [@event]
      end

      it 'returns only events that have a selected tag with undefined query input' do
        assert_equal EventSearchService.new(filter: { tag_ids: ["1"] }).results, [@event]
      end
    end

    describe 'with four events, two with one matching tag each, one with two matching tags, one without matching tag' do
      before do
        @event = make_event
        @ruby_event = make_event
        @java_event = make_event
        @ruby_java_event = make_event
        ruby_tag = Tag.create!(id: 1, name: 'Ruby', category: Category.create!(name: 'Programming language'))
        java_tag = Tag.create!(id: 2, name: 'Java', category: Category.create!(name: 'Programming language'))
        Tagging.create!(event: @ruby_event, tag: ruby_tag)
        Tagging.create!(event: @java_event, tag: java_tag)
        Tagging.create!(event: @ruby_java_event, tag: ruby_tag)
        Tagging.create!(event: @ruby_java_event, tag: java_tag)
      end

      it 'returns three events' do
        assert_equal EventSearchService.new(filter: { tag_ids: ["1", "2"] }).results, [@ruby_event, @java_event, @ruby_java_event]
      end
    end
  end

  describe 'filtering events by keywords'  do
    describe 'with two events' do
      before do
        @event = make_event(city: 'Augsburg', description: 'This is a ruby event')
        @event2 = make_event(name: 'RubyCon')
      end

      it 'returns all events with defined empty string' do
        assert_equal [@event, @event2], EventSearchService.new(query: '').results
      end

      it 'returns all events without defined empty string' do
        assert_equal [@event.id, @event2.id], EventSearchService.new({}).results.map(&:id)
      end

      it 'returns one event with matching keyword query' do
        assert_equal [@event.id], EventSearchService.new(query: 'Augsburg').results.map(&:id)
      end

      it 'returns two events with matching keyword query' do
        assert_equal [@event.id, @event2.id], EventSearchService.new(query: 'Ruby').results.map(&:id)
      end
    end
  end

  describe 'filtering events by keywords and tags'  do
    describe 'with four events' do
      before do
        @event = make_event(city: 'New York')
        @ruby_event = make_event(name: 'New CodeCamp')
        @java_event = make_event(description: 'This is a new event.')
        @ruby_java_event = make_event
        ruby_tag = Tag.create!(id: 1, name: 'Ruby', category: Category.create!(name: 'Programming language'))
        java_tag = Tag.create!(id: 2, name: 'Java', category: Category.create!(name: 'Programming language'))
        Tagging.create!(event: @ruby_event, tag: ruby_tag)
        Tagging.create!(event: @java_event, tag: java_tag)
        Tagging.create!(event: @ruby_java_event, tag: ruby_tag)
        Tagging.create!(event: @ruby_java_event, tag: java_tag)
      end

      it 'returns only the one ruby event with matching keyword and tags' do
        assert_equal [@ruby_event.id], EventSearchService.new(query: 'New', filter: { tag_ids: ["1"] }).results.map(&:id)
      end

      it 'returns two events with matching keyword and tags' do
        assert_equal [@ruby_event.id, @java_event.id], EventSearchService.new(query: 'New', filter: { tag_ids: ["1", "2"] }).results.map(&:id)
      end

      it 'raises exception for non-existent tag-search' do
        assert_raises { EventSearchService.new(filter: { tag_ids: ["1", "2", "3"] }).results.map(&:id) }
      end
    end
  end
end
