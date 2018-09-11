class EventSearchService
  def initialize(params)
    params[:query] = [] if params[:query] == nil
    params[:filter] = {tag_ids:[]} if params[:filter] == nil
    @query = params[:query]
    @tag_ids = params[:filter][:tag_ids].reject(&:empty?)
  end

  def results
    tag_results(query_results(Event.all))
  end

  def selected_tags
    @tag_ids.map {|tag_id| Tag.where(id: tag_id.to_i)}
  end

  private

  def tag_results(events)
    return events if @tag_ids.blank?
    raise 'tag_id not existent' if @tag_ids.any? {|tag_id| Tag.pluck(:id).exclude? tag_id.to_i}
    ids = events.select do |event|
      @tag_ids.any? {|tag_id| event.tag_ids.include? tag_id.to_i}
    end.map(&:id)
    Event.where(id: ids)
  end

  def query_results(events)
    return events if @query.blank?
    events.where('name || description || city || country ILIKE ?', "%#{@query}%")
  end
end
