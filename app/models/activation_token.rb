# == Schema Information
# Schema version: 20101203135142
#
# Table name: activation_tokens
#
#  id         :integer         not null, primary key
#  token      :string(255)
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class ActivationToken < ActiveRecord::Base
  
  attr_accessible :token
  
  belongs_to :user
  
  validates :user_id,  :presence     => true
  validates :token,    :presence     => true
end
