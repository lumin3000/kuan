# Usage:
# rails console [ production | development | test ] < script/image_extend_version.rb

MISSING_VERSION = {
  photo: {
    :'400' => [400, 0],
    :'250' => [250, 0],
    :'150' => [150, 150],
    :'100' => [100, 0],
    :'75' => [75, 75],
  }
}

logger = Logger.new(Rails.root + 'log' + 'extend_image.log')

Pics.all.each do |post|
  post.photos.each do |photo|
    i = photo.image
    i.extend_version(MISSING_VERSION[:photo])
    i.save!
    logger.info "Did photo #{photo.id} of post #{post.id}"
  end
end
