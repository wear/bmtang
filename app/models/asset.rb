class Asset < ActiveRecord::Base
  belongs_to :attachable, :polymorphic => true  
  has_attachment prepare_options_for_attachment_fu(AppConfig.feature['attachment_fu_options']) 
end