# Usage:
# rails console [ production | development | test ] < script/image_extend_version.rb

MISSING_VERSION = {
  photo: {
    :'400' => [400, 0],
    :'250' => [250, 0],
    :'150' => [150, 150],
    :'100' => [100, 0],
    :'75' => [75, 75],
  },
  blog_icon: {
    :'128' => [128, 128],
    :'96' => [96, 96],
    :'64' => [64, 64],
    :'48' => [48, 48],
    :'40' => [40, 40],
    :'30' => [30, 30],
    :'16' => [16, 16],
  },
}

logger = Logger.new(Rails.root + 'log' + 'extend_image.log')

Blog.all.each do |b|
  i = b.icon
  if i.nil? || i.id.nil?
    logger.info "Blog #{b.uri} has no icon"
    next
  end
  i.extend_version(MISSING_VERSION[:blog_icon])
  i.save!
  logger.info "Did blog #{b.uri}"
end

Pics.all.each do |post|
  post.photos.each do |photo|
    i = photo.image
    i.extend_version(MISSING_VERSION[:photo])
    i.save!
    logger.info "Did photo #{photo.id} of post #{post.id}"
  end
end
