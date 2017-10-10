import pickle


def save_object(obj, filename):
    with open(filename, 'wb') as output:
        pickle.dump(obj, output, pickle.HIGHEST_PROTOCOL)


def load_object(filename):
    with open(filename, 'r') as input_obj:
        obj = pickle.load(input_obj)
    return obj
