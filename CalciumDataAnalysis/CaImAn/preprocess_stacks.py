from tifffile import TiffFile


class GenerateInitFile(object):
    def __init__(self, files, num_of_channels=1, channel_of_neurons=1):
        self.files = files
        self.num_of_channels = num_of_channels
        self.channel_of_neurons = channel_of_neurons
        self.metadata = None
        self.data = None

    def populate_file_list(self):
        with TiffFile(self.files[0]) as f:
            self.data = f.asarray()[-1+self.channel_of_neurons::self.num_of_channels]
            try:
                self.metadata = f.scanimage_metadata
            except:
                print("File not a SI-generated file.")


    def parse_metadata(self):
        # TODO
        pass