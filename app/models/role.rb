class Role < ApplicationRecord
  has_many :users, through: :role_users
  has_many :role_users

  def self.color_list
    [
      slotcolor1: {
        name_fr: "Bleu ciel couvert",
        name_en: "Dark sky blue",
        code: $myslot1,
      },
      slotcolor2: {
        name_fr: "Rose framboise",
        name_en: "Pink rasberry",
        code: $myslot2,
      },
      slotcolor3: {
        name_fr: "Or las-vegas",
        name_en: "Vegas gold",
        code: $myslot3,
      },
      slotcolor4: {
        name_fr: "Mauve lavande",
        name_en: "English lavender",
        code: $myslot4,
      },
      slotcolor5: {
        name_fr: "Brun castor",
        name_en: "Beaver",
        code: $myslot5,
      },
      slotcolor6: {
        name_fr: "Gris indépendance",
        name_en: "Independance",
        code: $myslot6,
      },
      slotcolor7: {
      name_fr: "Bleu nuit",
      name_en: "Midnight blue",
      code: $myslot7,
      },
      slotcolor8: {
        name_fr: "Jaune maïs",
        name_en: "Maize",
        code: $myslot8,
      },
      slotcolor9: {
        name_fr: "Violet Aubergine",
        name_en: "Eggplant",
        code: $myslot9,
      },
      slotcolor10: {
        name_fr: "Jaune ambre",
        name_en: "Ambre",
        code: $myslot10,
      }
    ]
  end

end
