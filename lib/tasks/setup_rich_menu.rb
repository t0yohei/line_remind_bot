require 'line/bot'

module Tasks
  class SetupRichMenu

    INITIAL_RICH_MENU_IMAGE_FILE_PATH = 'kaichu_dokei.png'.freeze

    class << self
      def execute
        setup_crient
        set_default_rich_menu

        # 以降追加があれば記載する

      end

      def set_default_rich_menu
        rich_menu_info = create_rich_menu
        set_as_default_rich_menu(rich_menu_info)
        insert_rich_menu(rich_menu_info)

      end

      def create_rich_menu
        image_id = upload_image_file
        rich_menu_info = register_rich_menu(image_id)
        return rich_menu_info
      end

      # リッチメニューで表示されるイメージファイルを登録
      def upload_image_file
        return image_id
      end

      # lineにリッチメニューを登録
      def register_rich_menu(image_id)
        # return rich_menu_info = {
        #   id: 'hogehoge',
        #   name: 'fugafuga'
        # }
      end

      def set_as_default_rich_menu(rich_menu_info)
      end

      # DBへの登録
      def insert_rich_menu(rich_menu_info)
      end

      def setup_crient
        @client = LineApiClient.new
      end


    end
  end
end
