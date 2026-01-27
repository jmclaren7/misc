using System;
using System.Drawing;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;
using System.Windows.Forms;

namespace TouchDisable
{
    static class Program
    {
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            bool createdNew;
            using (new Mutex(true, "TouchDisable_SingleInstance", out createdNew))
            {
                if (!createdNew)
                {
                    MessageBox.Show("Touch Disable is already running.", "Touch Disable",
                        MessageBoxButtons.OK, MessageBoxIcon.Information);
                    return;
                }
                Application.Run(new TrayApp());
            }
        }
    }

    class TrayApp : ApplicationContext
    {
        private NotifyIcon _tray;
        private ToolStripMenuItem _status, _enable, _disable;

        public TrayApp()
        {
            _status = new ToolStripMenuItem("Status: Checking...") { Enabled = false };
            _enable = new ToolStripMenuItem("Enable Touch Screen", null, (s, e) => SetEnabled(true));
            _disable = new ToolStripMenuItem("Disable Touch Screen", null, (s, e) => SetEnabled(false));

            var menu = new ContextMenuStrip();
            menu.Items.Add(_status);
            menu.Items.Add(new ToolStripSeparator());
            menu.Items.Add(_enable);
            menu.Items.Add(_disable);
            menu.Items.Add(new ToolStripSeparator());
            menu.Items.Add("Exit", null, (s, e) => { _tray.Visible = false; Application.Exit(); });

            _tray = new NotifyIcon
            {
                Icon = Icon.ExtractAssociatedIcon(Assembly.GetExecutingAssembly().Location) ?? SystemIcons.Application,
                ContextMenuStrip = menu,
                Visible = true,
                Text = "Touch Disable"
            };
            _tray.DoubleClick += (s, e) => SetEnabled(TouchScreen.IsEnabled() == false);

            UpdateStatus();
        }

        private void SetEnabled(bool enable)
        {
            if (!TouchScreen.SetEnabled(enable))
                MessageBox.Show("Failed to " + (enable ? "enable" : "disable") + " touch screen",
                    "Touch Disable", MessageBoxButtons.OK, MessageBoxIcon.Error);
            UpdateStatus();
        }

        private void UpdateStatus()
        {
            bool? enabled = TouchScreen.IsEnabled();
            if (enabled == null)
            {
                _status.Text = "Status: No touch screen found";
                _enable.Enabled = _disable.Enabled = false;
            }
            else
            {
                _status.Text = "Status: " + (enabled.Value ? "Enabled" : "Disabled");
                _enable.Enabled = !enabled.Value;
                _disable.Enabled = enabled.Value;
            }
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing) _tray.Dispose();
            base.Dispose(disposing);
        }
    }

    static class TouchScreen
    {
        static readonly Guid HID_GUID = new Guid("745a17a0-74d3-11d0-b6fe-00a0c90f57da");
        const int DIGCF_PRESENT = 0x02, SPDRP_DEVICEDESC = 0x00, DICS_ENABLE = 1, DICS_DISABLE = 2,
                  DICS_FLAG_GLOBAL = 1, DIF_PROPERTYCHANGE = 0x12, CM_PROB_DISABLED = 22;

        [StructLayout(LayoutKind.Sequential)]
        struct SP_DEVINFO_DATA { public int cbSize; public Guid ClassGuid; public int DevInst; public IntPtr Reserved; }

        [StructLayout(LayoutKind.Sequential)]
        struct SP_PROPCHANGE_PARAMS { public int hdrSize, hdrFunc, state, scope, profile; }

        [DllImport("setupapi.dll", SetLastError = true)]
        static extern IntPtr SetupDiGetClassDevs(ref Guid classGuid, IntPtr e, IntPtr h, int flags);
        [DllImport("setupapi.dll", SetLastError = true)]
        static extern bool SetupDiEnumDeviceInfo(IntPtr set, int idx, ref SP_DEVINFO_DATA data);
        [DllImport("setupapi.dll", SetLastError = true, CharSet = CharSet.Auto)]
        static extern bool SetupDiGetDeviceRegistryProperty(IntPtr set, ref SP_DEVINFO_DATA data, int prop, out int type, byte[] buf, int size, out int req);
        [DllImport("setupapi.dll", SetLastError = true)]
        static extern bool SetupDiSetClassInstallParams(IntPtr set, ref SP_DEVINFO_DATA data, ref SP_PROPCHANGE_PARAMS p, int size);
        [DllImport("setupapi.dll", SetLastError = true)]
        static extern bool SetupDiCallClassInstaller(int func, IntPtr set, ref SP_DEVINFO_DATA data);
        [DllImport("setupapi.dll", SetLastError = true)]
        static extern bool SetupDiDestroyDeviceInfoList(IntPtr set);
        [DllImport("setupapi.dll")]
        static extern int CM_Get_DevNode_Status(out int status, out int problem, int inst, int flags);

        public static bool? IsEnabled()
        {
            IntPtr set; SP_DEVINFO_DATA dev;
            if (!FindDevice(out set, out dev)) return null;
            try
            {
                int status, problem;
                return CM_Get_DevNode_Status(out status, out problem, dev.DevInst, 0) == 0 && problem != CM_PROB_DISABLED;
            }
            finally { SetupDiDestroyDeviceInfoList(set); }
        }

        public static bool SetEnabled(bool enable)
        {
            IntPtr set; SP_DEVINFO_DATA dev;
            if (!FindDevice(out set, out dev)) return false;
            try
            {
                var p = new SP_PROPCHANGE_PARAMS { hdrSize = 8, hdrFunc = DIF_PROPERTYCHANGE,
                    state = enable ? DICS_ENABLE : DICS_DISABLE, scope = DICS_FLAG_GLOBAL };
                return SetupDiSetClassInstallParams(set, ref dev, ref p, 20) &&
                       SetupDiCallClassInstaller(DIF_PROPERTYCHANGE, set, ref dev);
            }
            finally { SetupDiDestroyDeviceInfoList(set); }
        }

        static bool FindDevice(out IntPtr set, out SP_DEVINFO_DATA dev)
        {
            set = IntPtr.Zero;
            dev = new SP_DEVINFO_DATA { cbSize = Marshal.SizeOf(typeof(SP_DEVINFO_DATA)) };
            Guid guid = HID_GUID;
            set = SetupDiGetClassDevs(ref guid, IntPtr.Zero, IntPtr.Zero, DIGCF_PRESENT);
            if (set == IntPtr.Zero || set == new IntPtr(-1)) return false;

            for (int i = 0; SetupDiEnumDeviceInfo(set, i, ref dev); i++)
            {
                string desc = GetProperty(set, ref dev).ToLowerInvariant();
                if (desc.Contains("touchpad") || desc.Contains("trackpad") || desc.Contains("clickpad")) continue;
                if (desc.Contains("touch screen") || desc.Contains("touchscreen") || desc.Contains("digitizer"))
                    return true;
                dev.cbSize = Marshal.SizeOf(typeof(SP_DEVINFO_DATA));
            }
            SetupDiDestroyDeviceInfoList(set);
            set = IntPtr.Zero;
            return false;
        }

        static string GetProperty(IntPtr set, ref SP_DEVINFO_DATA dev)
        {
            byte[] buf = new byte[512]; int t, r;
            return SetupDiGetDeviceRegistryProperty(set, ref dev, SPDRP_DEVICEDESC, out t, buf, buf.Length, out r)
                ? Encoding.Unicode.GetString(buf).TrimEnd('\0') : "";
        }
    }
}
