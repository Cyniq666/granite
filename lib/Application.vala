//  
//  Copyright (C) 2011 Maxwell Barvian
// 
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
// 
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
// 
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
// 

using Gtk;

using Granite.Services;
using Granite.Widgets;

namespace Granite {

    /**
     * Global deprecated object..
     *
     * @deprecated 0.1
    **/
    public static Granite.Application app;

    public abstract class Application : Gtk.Application {

        public string build_data_dir;
        public string build_pkg_data_dir;
        public string build_release_name;
        public string build_version;
        public string build_version_info;

        public string program_name;
        public string exec_name;

        public string app_copyright;
        public string app_years;
        public string app_icon;
        public string app_launcher;

        public string main_url;
        public string bug_url;
        public string help_url;
        public string translate_url;

        public string[] about_authors;
        public string[] about_documenters;
        public string[] about_artists;
        public string about_comments;
        public string about_translators;
        public string about_license;
        public License about_license_type;

        public Application () {


            Granite.init ();
            // set program name
            prctl (15, exec_name, 0, 0, 0);
            Environment.set_prgname (exec_name);

            Logger.initialize (program_name);
            Logger.DisplayLevel = LogLevel.INFO;
            message ("%s version: %s", program_name, build_version);
            var un = Posix.utsname ();
            message ("Kernel version: %s", (string) un.release);
            Logger.DisplayLevel = LogLevel.WARN;

            Intl.bindtextdomain (exec_name, build_data_dir + "/locale");

            // Deprecated
            Granite.app = this;

        }

        [CCode (cheader_filename = "sys/prctl.h", cname = "prctl")]
            protected extern static int prctl (int option, string arg2, ulong arg3, ulong arg4, ulong arg5);

        public new int run (string[] args) {

            // parse commandline options
            var context = new OptionContext ("");

            context.add_main_entries (options, null);
            context.add_group (Gtk.get_option_group (false));

            try {
                context.parse (ref args);
            } catch { }

            set_options ();

            return base.run (args);
        }

        protected static bool DEBUG = false;

        protected const OptionEntry[] options = {
            { "debug", 'd', 0, OptionArg.NONE, out DEBUG, "Enable debug logging", null },
            { null }
        };

        protected virtual void set_options () {

            if (DEBUG)
                Logger.DisplayLevel = LogLevel.DEBUG;
        }

        public AppMenu create_appmenu (Gtk.Menu menu) {

            AppMenu app_menu = new AppMenu.with_app (this, menu);
            app_menu.show_about.connect (show_about);

            return app_menu;
        }

        protected Granite.Widgets.AboutDialog about_dlg;

        public virtual void show_about (Gtk.Widget parent) {

            assert(parent is Gtk.Window);
            Granite.Widgets.show_about_dialog ((Gtk.Window) parent, 
                                               "program_name", program_name,
                                               "version", build_version,
                                               "logo_icon_name", app_icon,

                                               "comments", about_comments,
                                               "copyright", "%s %s Developers".printf (app_years, program_name),
                                               "website", main_url,
                                               "website_label", "Website",

                                               "authors", about_authors,
                                               "documenters", about_documenters,
                                               "artists", about_artists,
                                               "translator_credits", about_translators,
                                               "license", about_license,
                                               "license_type", about_license_type,

                                               "help", help_url,
                                               "translate", translate_url,
                                               "bug", bug_url);

        }

    }

}
