# HeartSteps pilot data analysis

- [Mounting M+Box](#mouting-mbox)
- [Exporting data](#exporting-data)
- [Preparing data for analysis](#preparing-data-for-analysis)
- [Running data summaries](#running-data-summaries)
- [Content overview](#content-overview)

## Mounting M+Box

Connect to M+Box via [WebDAV](http://community.box.com/t5/Managing-Your-Content/Does-Box-support-WebDAV/ta-p/310) using the following steps. This allows you to access your M+Box folders as though they were part of your local filesystem.

1. From your [M+Box account settings](https://umich.app.box.com/settings/account), set up an external password. You will use this password and your primary M+Box email address (also found in settings) as the credentials to mount M+Box content.
2. Follow the system-specific instructions below.

### Mac

- Go to **Finder**, **Go**, **Connect to Server**.
- Enter the server address `https://dav.box.com/dav`.
- Click **Connect**. Select **Connect as Registered User**.
- Enter you M+Box primary email address (under **Name**) and your M+Box external password.

The mount point for your M+Box account's root folder should be `/Volumes/dav`.

### Windows

- Access the Map Network Drive menu, using the instructions for your Windows version.
  - Windows 8+: Open File Explorer, from either the Start Menu (Windows 10) or the Taskbar. Click **This PC** (this will likely be listed in **Frequent Folders**, but if not, find it in the sidebar). Click **Map Network Drive** in the ribbon at the top of the window. If you do not see this, click the **Computer** tab next to the blue File button.
  - Windows 7: Click **Start**, then **Computer**. Click **Map network drive** near the top of the window.
- From the **Drive** dropdown menu, choose `Z:\`.
- In **Folder**, enter `https://dav.box.com/dav`.
- Check the **Connect using different credentials** box, then click **Finish**.
- Enter your M+Box primary email address (under user name) and external M+Box password. Click **OK**.

You may need to close and reopen File Explorer for the new drive to appear.

### Ubuntu

- Install the WebDAV client [davfs2](http://savannah.nongnu.org/projects/davfs2) and create a mount point called `mbox` in your home directory with the following terminal commands. Here `USER` should be replaced with your own system login name.
```shell
sudo sed -ir 's/^# use_locks(.+)1$/# use_locks\10/g' /etc/davfs2/davfs2.conf
sudo dpkg-reconfigure davfs2
sudo usermod -a -G davfs2 USER
mkdir ~/mbox
echo "https://dav.box.com/dav /home/USER/mbox davfs rw,user,noauto 0 0" | sudo tee -a /etc/fstab
chmod 600 /home/USER/.davfs2/secrets
```
- Logout and log back in.
- M+Box can now be mounted with the command `mount ~/mbox` and unmounted with `umount ~/mbox`. When prompted, enter the credentials you set up in step 1.

## Exporting data

Application data are exported either manually through a web browser interface or via the export scripts in this repository. Data recorded by hand, such as message tags and intake/exit interviews, are exported manually by saving the corresponding file in CSV format. For this task, be sure to set your Excel locale to US English.

### Jawbone and Google Fit

Download using the browser interface at <http://jitai-api.appspot.com>. Server errors tend to occur when downloading large files, so the data should be downloaded month by month.

### HeartSteps

Ensure your system has [M+Box mounted](#mounting-mbox) and the following software installed.

- [Google App Engine Python SDK](https://cloud.google.com/appengine/downloads)
- [Python 2.7+](https://www.python.org/downloads/)

From the command line, navigate to the `heartstepsdata/exporter` folder in your local copy of this repository. Run the export script specific to your system. When prompted, enter the HeartSteps GAE account credentials.

## Preparing data for analysis

Ensure your system has [M+Box mounted](#mounting-mbox). From the command line, navigate to your local copy of this repository. Run the following:
```shell
R CMD BATCH --vanilla workspace.csv.R
R CMD BATCH --vanilla workspace.analysis.R
```
These R scripts will create or update two R workspace files, `csv.RData` and `analysis.RData` on M+Box. Previous versions of the files can be restored using the M+Box web interface.

## Running data summaries

## Content overview

File | Description
--- | ---
[ema.options.R](ema.options.R) | Response options for each EMA question
[functions.R](functions.R) | Helper functions, mainly for data formatting
[init.R](init.R) | Set common variables—run this at the beginning of ever R session
[read.data.R](read.data.R) | Read and tidy up CSV-formatted data
[summary.R](summary.R) | Extra code for the data summary
[summary.Rnw](summary.Rnw) | [knitr](http://yihui.name/knitr/) document for the data summary
[workspace.analysis.R](workspace.analysis.R) | Create a workspace file containing data frames for analysis
[workspace.csv.R](workspace.csv.R) | Create a workspace file containing data frames for the source data files
[xzoo.R](xzoo.R) | Extensions for the time series R package zoo
