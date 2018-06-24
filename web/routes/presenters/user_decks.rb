module Web
  module Routes
    module Presenters
      class UserDecks
        def initialize(user)
          @user = user
        end

        def context
          {
            decks: {
              list: decks,
              paginated: false,
            },
          }
        end

        private

        def decks
          @decks ||= Queries::Decks.for_user(@user).all
        end
      end
    end
  end
end