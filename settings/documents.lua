-----------------------------------------------------------------
-- Configuration options for scripted systems in this pack
-----------------------------------------------------------------
-- If you have changed your Windows 'Documents' folder to a
--   different drive/location, you will need to specify the path below
-- ie. If your Documents path is 'D:\Documents', the value below should be:
--   CONFIG.DOCUMENTS_FOLDER = "D:\\"
--
-- CONFIG.EMOTRACKER_FOLDER is the folder that EmoTracker uses for overrides and
--   saves. Only change this if this folder structure is different on your system.
--
-- CONFIG.OUTPUT_FOLDER is the folder that output txt files will be saved to.
-- By default, this uses the same folder as DOCUMENTS_FOLDER
--
-- Please note, backslashes need to be doubled and all folders needs to end with \\
-----------------------------------------------------------------

CONFIG.DOCUMENTS_FOLDER = os.getenv("UserProfile") .. "\\"
CONFIG.OUTPUT_FOLDER = CONFIG.DOCUMENTS_FOLDER
