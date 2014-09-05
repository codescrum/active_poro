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
          # set the instance variable only if I am now the rightful owner
          instance_variable_set("@#{target_name}", members || [])
          reflected_association_name = self.class.name.underscore
          members.each do |member|

            current_owner = member.send(reflected_association_name)
            if current_owner.nil? # no current assignment
              member.send "#{reflected_association_name}=", self
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
              member.send "#{reflected_association_name}=", self
            else
              # its already me, do not do anything
            end

          end
        end
      end

      def has_one(target_name)
        # define getter method
        define_method target_name do
          instance_variable_get("@#{target_name}") || []
        end

        # define setter method
        define_method "#{target_name}=" do |member|
          reflected_association_name = self.class.name.underscore
          unless member.send(reflected_association_name) == self
            member.send "#{reflected_association_name}=", self
          end
          instance_variable_set("@#{target_name}", member || [])
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
          reflected_association_name = self.class.name.underscore
          # add myself to reflected association
          if member.respond_to? reflected_association_name
            unless member.send(reflected_association_name) == self
              member.send("#{reflected_association_name}=", self)
            end
          elsif member.respond_to? reflected_association_name.pluralize
            reflected_members = member.send(reflected_association_name.pluralize)
            unless reflected_members.include? self
              member.send("#{reflected_association_name.pluralize}=", reflected_members + [self])
            end
          else
            raise "Association definition missing: no #{reflected_association_name} or #{reflected_association_name.pluralize} association defined in #{member.class}"
          end

          # remove myself from old reflected association
          if previous_member.respond_to? reflected_association_name
            if previous_member.send(reflected_association_name) == self
              previous_member.send("#{reflected_association_name}=", nil)
            end
          elsif previous_member.respond_to? reflected_association_name.pluralize
            previous_reflected_members = previous_member.send(reflected_association_name.pluralize)
            if previous_reflected_members.include? self
              previous_member.send("#{reflected_association_name.pluralize}=", previous_reflected_members - [self])
            end
          elsif previous_member.nil?
            # there was not previous member
          else # there was a previous member
            raise "Ghost association definition: no #{reflected_association_name} or #{reflected_association_name.pluralize} association defined in #{member.class}, although it was there previously, dirty contamination"
          end
        end
      end
    end

  end
end
