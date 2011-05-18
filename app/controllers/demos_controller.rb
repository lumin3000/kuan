# -*- coding: utf-8 -*-
class DemosController < ApplicationController
  def kdtnew
  end

  def kdtcreate
    require 'kdt/colortext'
    str = ColorText.instance.generate params[:content]
    render :text => str, :content_type => 'text/plain'
  end

end
