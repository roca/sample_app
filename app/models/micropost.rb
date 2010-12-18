# == Schema Information
# Schema version: 20101119202650
#
# Table name: microposts
#
#  id         :integer         not null, primary key
#  content    :string(255)
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

    

class Micropost < ActiveRecord::Base
  
  
   attr_accessible :content
   
   belongs_to :user
   
   default_scope :order => 'microposts.created_at DESC'
   
   
   validates :user_id,  :presence     => true
   validates :content,  :presence     => true,
                        :length       => { :maximum      => 140 }
   
   scope :from_users_followed_by , lambda { |user| followed_by(user)}
   
   scope :search , lambda { |fragment| search_by_string_fragment(fragment)}
   
   
 private 
   
  def self.followed_by(user)
    followed_ids = %(SELECT followed_id FROM relationships WHERE follower_id = :user_id)
    where("user_id IN (#{followed_ids}) OR user_id = :user_id", :user_id => user)
  end
  
  def self.search_by_string_fragment(fragment)
    
    
        if fragment.blank?
          all
        else
          fragments = fragment.split
          
          first_fragment = fragments.shift
          result = where("(content like :content)",{:content => "%#{first_fragment}%"})   
                
          fragments.each { |f|
            result = result.where("(content like :content)",{:content => "%#{f}%"})
          }
          
        end
        
        return result
  
  end
   
end
