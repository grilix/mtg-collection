require_relative '../views/html'

module Web
  module Helpers
    module CommonHelper
      def unprocessable!
        error!(status: 422)
      end

      def unauthorized!
        error!(status: 403)
      end

      def not_found!
        error!(status: 404)
      end

      def redirect_to(path)
        res.redirect(path)

        halt(res.finish)
      end

      def redirect_back(fallback)
        path =
          if (back = req.env['HTTP_REFERER']) && !back.empty?
            back
          else
            fallback
          end

        redirect_to(path)
      end

      def error!(status:)
        res.status = status

        halt(res.finish)
      end

      def render_view(view, context = {})
        res['Content-Type'] = 'text/html'

        html_opts = {
          csrf_token: csrf.token,
          params: req.params,
        }

        out = Web::Views::Html.render(html_opts) do |html|
          view.render(html, {
            current_user: current_user,
            csrf_token: csrf.token,
            params: req.params,
          }.merge(context))
        end

        res.write(out)
        res.status ||= 200
        halt(res.finish)
      end

      def send_as_file(filename, content)
        res.headers['Content-Description'] = 'File Transfer'
        res.headers['Content-Type'] = 'application/octet-stream'
        res.headers['Content-Disposition'] = 'attachment; filename="' + filename + '"'
        res.headers['Expires'] = '0'
        res.headers['Cache-Control'] = 'must-revalidate'
        res.headers['Pragma'] = 'public'
        res.headers['Content-Length'] = content.size

        res.status = 200
        res.write(content)
        halt(res.finish)
      end
    end
  end
end
