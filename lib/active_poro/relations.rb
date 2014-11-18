module ActivePoro
  module Relations
    extend ActiveSupport::Concern

    module ClassMethods
      def has_many(target_name)

        # define getter method
        define_method target_name do
          instance_variable_get("@#{target_name}") || []
        end

        # define setter method
        define_method "#{target_name}=" do |members|

          # nil to empty
          members ||= []

          # set the instance variable only if I am now the rightful owner
          instance_variable_set("@#{target_name}", members)
          singular_reflection_name = self.class.name.underscore
          members.each do |member|

            current_owner = member.send(singular_reflection_name)
            if current_owner.nil? # no current assignment
              member.send "#{singular_reflection_name}=", self
            elsif current_owner != self # current assignment is not me
              other_members = current_owner.send target_name
              if other_members.include?(member)
                # take the element from the other member
                new_members = other_members - [member]
                current_owner.send "#{target_name}=", new_members
              else
                raise "Unmatching association; Current owner (#{current_owner.class.name}) of #{member.class.name} does not have it as a member"
              end
              # add me as associated to the member I am also including
              member.send "#{singular_reflection_name}=", self
            else
              # its already me, do not do anything
            end

          end
        end

        # the singular suffix for add and remove methods
        singular_target_name = target_name.to_s.singularize

        # define the "add_<name>" method
        define_method "add_#{singular_target_name}" do |member|
          send("#{target_name}=", (send(target_name) + [member]).uniq)
        end

        # define the "remove_<name>" method
        define_method "remove_#{singular_target_name}" do |member|
          send("#{target_name}=", (send(target_name) - [member]).uniq)
        end

      end

      def has_one(target_name)
        # define getter method
        define_method target_name do
          instance_variable_get("@#{target_name}")
        end

        # define setter method
        define_method "#{target_name}=" do |member|
          singular_reflection_name = self.class.name.underscore
          if member.respond_to?(singular_reflection_name) && member.send(singular_reflection_name) != self
            member.send "#{singular_reflection_name}=", self
          end
          instance_variable_set("@#{target_name}", member)
        end
      end

      def belongs_to(target_name)
        # define getter method
        define_method target_name do
          instance_variable_get("@#{target_name}")
        end

        # define setter method
        define_method "#{target_name}=" do |member|
          previous_member = instance_variable_get("@#{target_name}")
          instance_variable_set("@#{target_name}", member)

          singular_reflection_name = self.class.name.underscore
          plural_reflection_name = singular_reflection_name.pluralize

          # add myself to reflected association
          if member.respond_to?(singular_reflection_name) && member.send(singular_reflection_name) != self
            member.send("#{singular_reflection_name}=", self)
          elsif member.respond_to? plural_reflection_name
            reflected_members = member.send(plural_reflection_name)
            member.send("#{plural_reflection_name}=", reflected_members + [self]) unless reflected_members.include? self
          else
            raise "Association definition missing: no #{singular_reflection_name} or #{plural_reflection_name} association defined in #{member.class}"
          end

          # remove myself from old reflected association
          if previous_member.respond_to? singular_reflection_name
              previous_member.send("#{singular_reflection_name}=", nil) if previous_member.send(singular_reflection_name) == self
          elsif previous_member.respond_to? plural_reflection_name
            previous_reflected_members = previous_member.send(plural_reflection_name)
            previous_member.send("#{plural_reflection_name}=", previous_reflected_members - [self]) if previous_reflected_members.include? self
          elsif previous_member.nil?
            # there wasn't any previous member
          else # there was a previous member
            raise "Ghost association definition: no #{singular_reflection_name} or #{plural_reflection_name} association defined in #{member.class}, although it was there previously, dirty contamination"
          end
        end
      end
    end

  end
end
