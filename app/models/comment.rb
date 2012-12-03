# encoding: UTF-8
class Comment < ActiveRecord::Base
  attr_accessible :idea, :parent, :author, :rating, :body
  attr_accessible :idea_id, :parent_id

  belongs_to :idea
  belongs_to :parent,   :class_name => 'Comment'
  has_many   :children, :class_name => 'Comment', :foreign_key => :parent_id,
                        :dependent => :destroy
  belongs_to :author,   :class_name => 'User'
  has_many   :votes, :as => :subject, :dependent => :destroy
  has_one    :attachment, :class_name => 'Attachment', :as => :owner, :dependent => :destroy
  include Notification::Base::CanBeSubject  

  default_values rating: 0

  validates_presence_of :author
  validates_presence_of :idea
  validates_presence_of :body
  validates_presence_of :rating

  default_scope order('created_at DESC')

  scope :recently_updated, lambda { where('updated_at > ?', 15.minutes.ago) }

  after_create { |record| record.idea.andand.ping! }
end
