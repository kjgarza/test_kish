class EventdataJob
  include SuckerPunch::Job
  workers 4 
  max_jobs 10


  def perform(event)
    ResolutionEvent.push_instance(event).track
  end
end