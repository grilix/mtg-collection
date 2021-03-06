require_relative 'presenters/deck_card_alternatives'
require_relative 'presenters/deck_card_list'
require_relative 'presenters/deck_cards'
require_relative 'presenters/deck_card_synergy'
require_relative 'presenters/deck_suggestions'
require_relative 'presenters/edit_deck_cards'
require_relative 'presenters/link_deck_cards'
require_relative 'presenters/user_decks'

require_relative '../views/decks/add_cards'
require_relative '../views/decks/alternatives'
require_relative '../views/decks/card_list'
require_relative '../views/decks/edit_cards'
require_relative '../views/decks/find_cards'
require_relative '../views/decks/link_cards'
require_relative '../views/decks/list'
require_relative '../views/decks/new'
require_relative '../views/decks/show'
require_relative '../views/decks/synergy'

module Web
  module Routes
    class Decks < Web::Server
      define do
        require_login!

        on(root) do
          on(get) do
            presenter = Routes::Presenters::UserDecks.new(current_user, {
              params: req.params,
            })

            render_view(Web::Views::Decks::List.static, presenter.context)
          end
        end

        on(post, 'import-list', param('deck')) do |params|
          deck = Services::Decks::FromList.create(current_user, {
            name: params['name'],
            list: params['list'].split(/[\n\r]+/)
          })

          redirect_to("/decks/#{deck[:id]}")
        end

        on('new') do
          on(get, root) do
            render_view(Web::Views::Decks::New.static, {})
          end
        end

        on('find') do
          on(get, root) do
            presenter = Routes::Presenters::FindDecks.new(current_user, {
              params: req.params,
            })

            render_view(Web::Views::Decks::Find.static, presenter.context)
          end
        end

        on('(\d+)') do |id|
          deck = current_user.decks_dataset.where(id: id).first
          not_found! unless deck

          on(delete, root) do
            Services::Decks::Delete.deck(id)
            redirect_to('/decks')
          end

          on(get, 'edit') do
            presenter = Routes::Presenters::EditDeckCards.new(
              current_user, deck,
              { params: req.params },
            )

            render_view(Web::Views::Decks::EditCards.static, presenter.context)
          end

          on(get, root) do
            presenter = Routes::Presenters::DeckCards.new(current_user, deck, {
              params: req.params,
            })

            render_view(Web::Views::Decks::Show.static, presenter.context)
          end

          on(get, 'add-cards') do
            presenter = Routes::Presenters::DeckCards.new(current_user, deck, {
              params: req.params,
            })

            render_view(Web::Views::Decks::AddCards.static, presenter.context)
          end

          on(post, 'add-cards', param('deck')) do |params|
            Services::Decks::FromList.add_cards(deck, {
              list: params['list'].split(/[\n\r]+/),
              scratchpad: params['scratchpad']
            })

            redirect_to("/decks/#{deck[:id]}/edit")
          end

          on(get, 'find-cards') do
            presenter = Routes::Presenters::DeckSuggestions.new(
              current_user,
              deck,
              params: req.params
            )

            render_view(Web::Views::Decks::FindCards.static, presenter.context)
          end

          on(get, 'link') do
            presenter = Routes::Presenters::LinkDeckCards.new(
              current_user,
              deck,
              params: req.params
            )

            render_view(Web::Views::Decks::LinkCards.static, presenter.context)
          end

          on(get, 'list') do
            presenter = Presenters::DeckCardList.new(deck)
            render_view(Views::Decks::CardList.static, presenter.context)
          end

          on('cards') do
            on(post, param('slot'), root) do |slot, card_id|
              card_id = req.params['card_id']
              card_id &&= card_id.to_i
              user_printing_id = req.params['user_printing_id']
              user_printing_id &&= user_printing_id.to_i

              Services::Decks::AddCard.perform(deck, slot, {
                card_id: card_id,
                user_printing_id: user_printing_id,
              })


              redirect_back("/decks/#{deck[:id]}")
            end

            on('(\d+)') do |card_id|
              card = Card.first(id: card_id)
              not_found! unless card

              on(get, 'alternatives') do
                presenter = Web::Routes::Presenters::DeckCardAlternatives.new(
                  current_user, deck, card,
                  { params: req.params }
                )

                render_view(
                  Web::Views::Decks::Alternatives.static, presenter.context
                )
              end

              on(get, 'synergy') do
                presenter = Web::Routes::Presenters::DeckCardSynergy.new(
                  current_user, deck, card,
                  { params: req.params }
                )

                render_view(
                  Web::Views::Decks::Synergy.static,
                  presenter.context
                )
              end
            end
          end
        end
      end
    end
  end
end
