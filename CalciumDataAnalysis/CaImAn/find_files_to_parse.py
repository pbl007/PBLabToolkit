from pathlib2 import Path
import Tkinter, tkFileDialog



class FileFinder(object):
    stromboli_prefix = Path('/state/partition1/home/pblab')
    parent_folder = None

    def find_files(self):
        """
        Find all files in a folder
        :return: List of files to parse, first one being the init stack
        """
        path_to_folder = self.update_prefix()
        files_in_folder = self.get_files(path=path_to_folder)
        return files_in_folder

    def update_prefix(self):
        p = Path(r"/data")
        if not p.exists():
            p = self.stromboli_prefix / p
        if not p.exists():
            raise TypeError("{} not a path.".format(str(p)))

        return p

    def get_files(self, path='.'):
        root = Tkinter.Tk()
        root.withdraw()
        files = tkFileDialog.askopenfilenames(parent=root, title='Choose files to parse (same FOV)',
                                              filetypes=[('Tif files', '*.tif'), ('HDF5 files', '*.h5')],
                                              initialdir=path)
        self.parent_folder = Path(files[0]).parent.absolute()
        return files