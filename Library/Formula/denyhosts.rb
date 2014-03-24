  depends_on :python


    unless MacOS.mountain_lion_or_newer?
      inreplace 'denyhosts.cfg' do |s|
        s.gsub! %r{^SECURE_LOG\s*=\s*/private/var/log/system\.log}, 'SECURE_LOG = /private/var/log/secure.log'
      end
    end

    python do
      system python, "setup.py", "install",
                                 "--prefix=#{prefix}",
                                 "--install-scripts=#{bin}",
                                 "--install-data=#{libexec}"
    end
    etc.install 'denyhosts.cfg'
+#SECURE_LOG = /private/var/log/secure.log
+SECURE_LOG=/private/var/log/system.log