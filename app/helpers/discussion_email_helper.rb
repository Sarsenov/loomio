module DiscussionEmailHelper
  include PrettyUrlHelper

  def target_url(args = {}, eventable, recipient, action_name)
    membership = membership(eventable.discussion, recipient)
    args.merge!(membership_token: membership.token) if membership
    polymorphic_url(eventable, utm_hash(args, action_name))
  end

  def unfollow_url(discussion, action_name, recipient)
    utm_hash = utm_hash({discussion_id: discussion.id}, action_name)
    email_actions_unfollow_discussion_url(utm_hash.merge(unsubscribe_token: unsubscribe_token(recipient)))
  end

  def preferences_url(recipient, action_name)
    email_preferences_url(utm_hash({}, action_name).merge(unsubscribe_token: unsubscribe_token(recipient)))
  end

  def pixel_src(event, recipient)
    email_actions_mark_discussion_as_read_url(
      discussion_id:     event.eventable.discussion.id,
      event_id:          event.id,
      unsubscribe_token: recipient.unsubscribe_token,
      format: 'gif'
    )
  end

  def can_unfollow?(discussion, recipient, action_name)
    action_name == 'new_comment' &&
    DiscussionReader.for(discussion: discussion, user: recipient).volume_is_normal_or_loud?
  end

  private

  def membership(discussion, recipient)
    discussion.guest_group.memberships.find_by(user: recipient)
  end

  def utm_hash(args = {}, action_name)
    {
      utm_medium: 'email',
      utm_campaign: 'discussion_mailer',
      utm_source: action_name
    }.merge(args)
  end

  def unsubscribe_token(recipient)
    recipient.unsubscribe_token || 'none'
  end

end


# class DiscussionEmailInfo
#   include PrettyUrlHelper
#   attr_reader :recipient, :event, :action_name
#
#   def initialize(recipient:, event:, action_name:)
#     @recipient = recipient
#     @event = event
#     @action_name = action_name
#   end
#
#   # So far eventable can be: Discussion, Comment, or Invitation
#   def eventable
#     @eventable ||= event.eventable
#   end
#
#   def actor
#     @actor ||= event.user
#   end
#
#   def discussion
#     @discussion ||= eventable.discussion
#   end
#
#   def target_url(args = {})
#     args.merge!(membership_token: membership.token) if membership
#     polymorphic_url(eventable, utm_hash(args))
#   end
#
#   def unfollow_url(args = {})
#     email_actions_unfollow_discussion_url(utm_hash(discussion_id: discussion.id).merge(unsubscribe_token: unsubscribe_token))
#   end
#
#   def preferences_url
#     email_preferences_url(utm_hash.merge(unsubscribe_token: unsubscribe_token))
#   end
#
#   def pixel_src
#     email_actions_mark_discussion_as_read_url(
#       discussion_id:     discussion.id,
#       event_id:          event.id,
#       unsubscribe_token: recipient.unsubscribe_token,
#       format: 'gif'
#     )
#   end
#
#   def can_unfollow?
#     action_name == 'new_comment' &&
#     DiscussionReader.for(discussion: discussion, user: recipient).volume_is_normal_or_loud?
#   end
#
#   private
#
#   def membership
#     @membership ||= discussion.guest_group.memberships.find_by(user: recipient)
#   end
#
#   def utm_hash(args = {})
#     {
#       utm_medium: 'email',
#       utm_campaign: 'discussion_mailer',
#       utm_source: action_name
#     }.merge(args)
#   end
#
#   def unsubscribe_token
#     recipient.unsubscribe_token || 'none'
#   end
# end