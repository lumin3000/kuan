# -*- coding: utf-8 -*-
class DemosController < ApplicationController
  def kdtnew
  end

  def kdtcreate
    require 'kdt/colortext'
    file = ColorText.new.generate params[:content]
    open(file, 'rb') {|io| render :text => io.read, :content_type => "image/png"}
  end

end
