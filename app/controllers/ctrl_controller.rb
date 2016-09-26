# require './app/jobs/wzqeryworker.rb'
class CtrlController < ApplicationController
  def begin_all
  	QueryWorker.perform_async('hah',250)
  	
  	redirect_to '/a',notice: "ok"
  end
end
