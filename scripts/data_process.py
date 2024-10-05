""" File to process data before saving in a csv
"""

# Imports
import sys
import argparse
import pandas as pd


# Processing function
def process_data(
    file_path: str
) -> pd.DataFrame:
    """Data processing function

    Parameters
    ----------
    file_path : str
        input file_path

    Returns
    -------
    pd.DataFrame
        Processed DataFrame
    """
    categories = {
        'alcohol': 'Alcool',
        'exceptional': 'Exceptionnelle',
        'grocery': 'Course',
        'health': 'Santé',
        'leisure': 'Plaisir',
        'regular': 'Régulier',
        'restaurant': 'Restaurant',
        'trip': 'Voyage'
    }
    columns_to_rename = {
        'millisSinceEpochStart': 'Date',
        'type': 'Revenu/Dépense',
        'category': 'Type',
        'label': 'Intitulé',
        'value': 'Montant'
    }
    columns_to_drop = ['id', 'millisSinceEpochEnd']
    columns_order = ["Date", "Intitulé", "Montant", "Type", "Revenu/Dépense"]
    # Method chaining
    return (
        pd.read_csv(file_path)
        .assign(
            millisSinceEpochStart=lambda df: pd.to_datetime(df['millisSinceEpochStart'], unit='ms').dt.strftime('%m/%d/%Y'),
            type=lambda df: df['type'].map({'expense': -1, 'income': 1}),
            category=lambda df: df['category'].map(categories)
        )
        .rename(columns=columns_to_rename)
        .drop(columns=columns_to_drop)
        .reindex(columns_order, axis=1)
    )


# Main function
def main():
    """ Creates a parser to get the input output file paths
    and then process data
    """
    # Create parser
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--input_path', 
        type=str, 
        default="../data/exported_database.csv", 
        help="File to process"
    )
    parser.add_argument(
        '--output_path', 
        type=str, 
        default="../data/expenses.csv", 
        help="Path to save processed file"
    )
    
    # Call function
    try:
        args = parser.parse_args()
        file_path, save_path = args.input_path, args.output_path
        processed_df = process_data(file_path)
        # Save df
        processed_df.to_csv(save_path, index=False)
    except Exception as err:
        print(err)
        return 1
    return 0
    
    
if __name__=="__main__":
    sys.exit(main())