class TemplatesController < ApplicationController
  def index
    @templates = Template.all
  end

  def edit
    @template = Template.find params[:id]
  end
end
