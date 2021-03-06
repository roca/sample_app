# == Schema Information
# Schema version: 20101219101824
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(255)
#  salt               :string(255)
#  admin              :boolean
#  username           :string(255)
#



class User < ActiveRecord::Base
  
  
   attr_accessor   :password
   attr_accessible :name, :username, :email, :password, :password_confirmation
   
   has_many :microposts,             :dependent   => :destroy
   has_many :microposts_from_others, :dependent   => :destroy,
                                     :foreign_key => "in_reply_to",
                                     :class_name =>  "Micropost"
                                     
   has_many :relationships,        :dependent   => :destroy,
                                   :foreign_key => "follower_id"                  
   has_many :reverse_relationships,:dependent   => :destroy,
                                   :foreign_key => "followed_id",
                                   :class_name  => "Relationship"                  
   has_many :following,            :through => :relationships,
                                   :source => :followed
   has_many :followers,            :through => :reverse_relationships,
                                   :source => :follower
   has_one  :activation_token,     :dependent   => :destroy
   
   email_regex    = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
   username_regex = /^[\w-]+$/i
   
   
   validates :name,     :presence     => true, 
                        :length       => { :maximum        => 50}
                       
   validates :username, :presence     => true,
                        :length       => { :maximum        => 50},
                        :format       => { :with           => username_regex },
                        :uniqueness   => { :case_sensitive => false}
                        
   validates :email,    :presence     => true,
                        :format       => { :with           => email_regex },
                        :uniqueness   => { :case_sensitive => false}
   
   validates :password, :presence     => true,
                        :confirmation => true,
                        :length       => { :within       => 6..40 }

  before_save :encrypt_password
  
   scope :search , lambda { |fragment| search_by_string_fragment(fragment)}
  
  def has_password?(submitted_password)
    self.encrypted_password == encrypt(submitted_password)
  end
  
  def active?
    !ActivationToken.find_by_user_id(self)
  end
  
  def activate
       activation_token = ActivationToken.find_by_user_id(self)
       activation_token.destroy if activation_token
  end
    
  def deactivate
    create_activation_token({:token => Digest::SHA2.hexdigest("#{Time.now.utc}--#{email}")})
   end
   
  def feed
    Micropost.from_users_sent_to_or_from_users_followed_by(self)
  end
  
  def following?(followed)
    !!relationships.find_by_followed_id(followed)
  end
  
  def follow!(followed)
    relationships.create!(:followed_id => followed.id)
  end
  
  def unfollow!(followed)
    relationships.find_by_followed_id(followed).destroy
  end
  
 
  
   def self.authenticate(email,submitted_password)
    user = find_by_email(email) || find_by_username(email)
    (user && user.has_password?(submitted_password)) ? user : nil
   end

   def self.authenticate_with_salt(id, cookie_salt)
       user = find_by_id(id)
       (user && user.salt == cookie_salt) ? user : nil
   end

   def self.authenticate_with_token(id,token)
        user = find_by_id(id)
        token = ActivationToken.find_by_token(token)
        (user && token && user == token.user) ? user : nil
    end

  
  private
  
    
      def encrypt_password
        self.salt = make_salt if new_record?
        self.encrypted_password = encrypt(self.password)
        
      end
      
      def encrypt(string)
         secure_hash("#{salt}--#{string}")
      end
      
      def make_salt
        secure_hash("#{Time.now.utc}--#{self.password}")
      end
      
      def secure_hash(string)
        Digest::SHA2.hexdigest(string)
      end
      
      def self.search_by_string_fragment(fragment)
         if fragment.blank?
           scoped
         else
           fragments = fragment.split
           
           first_fragment = fragments.shift
           fragment_hash = {:email => "%#{first_fragment}%", :name => "%#{first_fragment}%", :username => "%#{first_fragment}%"}          
           result = where("(email like :email or name like :name  or username like :username)",fragment_hash)   
                 
           fragments.each { |f|
             fragment_hash = {:email => "%#{f}%", :name => "%#{f}%", :username => "%#{f}%"}          
             result = result.where("(email like :email or name like :name  or username like :username)",fragment_hash)
           }
           
         end
         
         return result

      end
end
