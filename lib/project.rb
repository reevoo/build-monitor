class Project
  attr_reader :name

  def initialize(opts={})
    @name = opts.fetch("name")
    @builds = opts.fetch("builds").map{|hash| Build.new(hash)}
    @ignored = opts.fetch(:ignored)
  end

  def latest_complete_build
    @builds.find(&:complete?)
  end

  def build_in_progress?
    @builds.first.in_progress?
  end

  def builds_since_last_success
    @builds
      .take_while { |build| build.in_progress? || build.failed? }
      .reject { |build| build.in_progress? }
      .count
  end

  def ignored?
    @ignored
  end
end
