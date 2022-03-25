-----------------------------------------------------------------
-- Configuration options for scripted systems in this pack
-----------------------------------------------------------------
-- If you have changed your Windows 'Documents' folder to a
--   different drive/location, you will need to specify the path below
-- ie. If your Documents path is 'D:\Documents', the value below should be:
--   CONFIG.DOCUMENTS_FOLDER = "D:\\"
-- Please note, backslashes need to be doubled and the value needs to end with \\
-----------------------------------------------------------------

CONFIG.DOCUMENTS_FOLDER = os.getenv("UserProfile") .. "\\"
