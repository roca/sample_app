# == Schema Information
# Schema version: 20101219101824
#
# Table name: microposts
#
#  id          :integer         not null, primary key
#  content     :string(255)
#  user_id     :integer
#  created_at  :datetime
#  updated_at  :datetime
#  in_reply_to :integer
#

    

class Micropost < ActiveRecord::Base
  
  
   attr_accessible :content,:in_reply_to
   
   belongs_to :user 
   
   belongs_to :recipient , :foreign_key => "in_reply_to"  , :class_name => "User"
      
   
   validates :user_id,  :presence     => true
   validates :content,  :presence     => true,
                        :length       => { :maximum      => 140 }
   
   
   default_scope :order => 'microposts.created_at DESC'

   scope :from_users_followed_by , lambda { |user| followed_by(user)}
   
   scope :from_users_sent_to     , lambda { |user| sent_to(user)}
   
   scope :from_users_sent_to_or_from_users_followed_by     , lambda { |user| sent_to_or_followed_by(user)}
    
   scope :search , lambda { |fragment| search_by_string_fragment(fragment)}
   
   
 private 
   
  def self.followed_by(user)
    followed_ids = %(SELECT followed_id FROM relationships WHERE follower_id = :user_id)
    where("user_id IN (#{followed_ids}) OR user_id = :user_id", :user_id => user) 
  end
  
  def self.sent_to(user)
    user.microposts_from_others
  end
  
  def self.sent_to_or_followed_by(user)
    followed_ids = %(SELECT followed_id FROM relationships WHERE follower_id = :user_id)
     where("(user_id IN (#{followed_ids}) OR user_id = :user_id) or (in_reply_to = :reply_id)", { :user_id => user, :reply_id => user}) 
  end
  
  def self.search_by_string_fragment(fragment)
    
    
        if fragment.blank?
          scoped
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
