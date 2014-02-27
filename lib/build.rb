class Build
  attr_reader :result, :timestamp

  def initialize(opts={})
    @result = opts.fetch("result")
    @building = opts.fetch("building")
    @result = @result.downcase.to_sym if @result
    @timestamp = Time.at(opts.fetch("timestamp").to_i)
  end

  def complete?
    !in_progress?
  end

  def in_progress?
    @building
  end

  def failed?
    complete? && result != :success
  end
end
